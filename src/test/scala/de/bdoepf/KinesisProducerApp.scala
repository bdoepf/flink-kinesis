package de.bdoepf

import com.amazonaws.regions.Regions
import de.bdoepfn.model.TestData
import jp.co.bizreach.kinesis.{AmazonKinesis, PutRecordRequest}

object KinesisProducerApp {

  def main(args: Array[String]): Unit = {
    val streamName = sys.env("STREAM_NAME")
    implicit val region = Regions.fromName(sys.env("REGION"))
    // use DefaultAWSCredentialsProviderChain
    val client = AmazonKinesis()

    for (i <- 0 until 100) {
      val record = TestData(i.toLong, s"test data with id $i")
      println(s"Putting record $record")
      client.putRecord(PutRecordRequest(
        streamName = streamName,
        partitionKey = i.toString,
        data = record.toByteArray
      ))
      Thread.sleep(1000L)
    }

  }
}
