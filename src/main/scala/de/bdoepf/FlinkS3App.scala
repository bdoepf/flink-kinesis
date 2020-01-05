package de.bdoepf

import java.util.Properties
import java.util.concurrent.TimeUnit

import de.bdoepfn.model.TestData
import com.amazonaws.services.kinesisanalytics.runtime.KinesisAnalyticsRuntime
import com.amazonaws.services.kinesisanalytics.flink.connectors.config.AWSConfigConstants
import org.apache.flink.api.common.serialization.DeserializationSchema
import org.apache.flink.api.common.typeinfo.TypeInformation
import org.apache.flink.core.io.SimpleVersionedSerializer
import org.apache.flink.streaming.api.functions.sink.filesystem.BucketAssigner
import org.apache.flink.api.common.functions.Partitioner
import org.apache.flink.core.fs.Path
import org.apache.flink.formats.parquet.avro.ParquetAvroWriters
import org.apache.flink.streaming.api.functions.sink.filesystem.StreamingFileSink
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.connectors.kinesis.FlinkKinesisConsumer
import org.apache.flink.streaming.connectors.kinesis.config.ConsumerConfigConstants
import org.slf4j.LoggerFactory

object FlinkS3App {
  private val log = LoggerFactory.getLogger(getClass.getName)
  val PROPERTY_GROUP_NAME = "FlinkS3AppProperties"
  val REGION_PROPERTY = "aws.region"
  val STREAM_NAME_PROPERTY = "stream.name"
  val OUTPUT_PATH_PROPERTY = "output.path"

  object KinesisPayloadDeserializer extends DeserializationSchema[TestData] {
    override def deserialize(message: Array[Byte]): TestData = TestData.parseFrom(message)

    override def isEndOfStream(nextElement: TestData): Boolean = false

    override def getProducedType: TypeInformation[TestData] = createTypeInformation[TestData]
  }

  def createKinesisSource(env: StreamExecutionEnvironment, region: String, streamName: String): DataStream[TestData] = {
    val inputProperties = new Properties()
    inputProperties.setProperty(AWSConfigConstants.AWS_REGION, region)
    inputProperties.setProperty(ConsumerConfigConstants.STREAM_INITIAL_POSITION,
      "TRIM_HORIZON")
    env.addSource(new FlinkKinesisConsumer(streamName,
      KinesisPayloadDeserializer,
      inputProperties))
  }

  object EvenBucketAssigner extends BucketAssigner[TestData, Even] {
    override def getBucketId(element: TestData, context: BucketAssigner.Context): Even = Even(element.id % 2 == 0)

    override def getSerializer: SimpleVersionedSerializer[Even] = new SimpleVersionedSerializer[Even] {
      override def getVersion: Int = 1

      override def serialize(obj: Even): Array[Byte] = if (obj.even) {
        Array[Byte](0)
      } else {
        Array[Byte](1)
      }

      override def deserialize(version: Int, serialized: Array[Byte]): Even = if (serialized(0) == 0) {
        Even(true)
      } else {
        Even(false)
      }
    }
  }

  object EvenPartitioner extends Partitioner[Long] {
    override def partition(key: Long, numPartitions: Int): Int = {
      (key % 2).toInt % numPartitions
    }
  }

  def main(args: Array[String]): Unit = {
    // Config
    val applicationProperties = KinesisAnalyticsRuntime.getApplicationProperties
    val properties = applicationProperties.get(PROPERTY_GROUP_NAME)
    val region = getProperty(properties, REGION_PROPERTY)
    val streamName = getProperty(properties, STREAM_NAME_PROPERTY)
    val outputPath = getProperty(properties, OUTPUT_PATH_PROPERTY)

    run(region, streamName, outputPath)
  }

  private[bdoepf] def run(region: String, streamName: String, outputPath: String) = {
    // Create env
    val env = StreamExecutionEnvironment
      .getExecutionEnvironment

    // Kinesis source, parse protobuf payload
    val source = createKinesisSource(env, region, streamName)

    // S3 sink
    val sink = StreamingFileSink.forBulkFormat(new Path(outputPath),
      ParquetAvroWriters.forReflectRecord(classOf[TestData])
    ) //.withBucketCheckInterval(TimeUnit.MINUTES.toMillis(1))
      .withBucketAssigner(EvenBucketAssigner)
      .build()

    // Process
    source
      .name("Kinesis Source")
      .uid("kinesis-source-id")
      // partition incoming messages by even and odd ids
      .partitionCustom(EvenPartitioner, x => x.id)
      // store data as parquet partitioned by even and odd ids
      .addSink(sink)
      .name("S3 Sink")
      .uid("s3-sink-id")

    env.execute("Flink-Test-Job")
  }

  private def getProperty(properties: Properties, propertyName: String) = {
    Option(properties.getProperty(propertyName)) match {
      case Some(p) => p
      case None =>
        val errorMsg = s"Property '$propertyName' not found in property group '$PROPERTY_GROUP_NAME'"
        log.error(errorMsg)
        throw new IllegalArgumentException(errorMsg)
    }
  }
}
