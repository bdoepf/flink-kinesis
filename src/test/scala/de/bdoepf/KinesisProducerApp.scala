package de.bdoepf

import java.util.Date

import com.amazonaws.regions.Regions
import de.bdoepfn.model.TestData
import jp.co.bizreach.kinesis.{AmazonKinesis, PutRecordRequest}
import java.text.SimpleDateFormat

object KinesisProducerApp {

  def main(args: Array[String]): Unit = {
    val streamName = sys.env("STREAM_NAME")
    implicit val region = Regions.fromName(sys.env("REGION"))
    val isoDatePattern = "yyyy-MM-dd' 'HH:mm:ss"
    val simpleDateFormat = new SimpleDateFormat(isoDatePattern)

    // use DefaultAWSCredentialsProviderChain
    val client = AmazonKinesis()

    for (i <- 0 until 3600) {
      val record = TestData(i.toLong, s"i=$i - ${simpleDateFormat.format(new Date(System.currentTimeMillis()))}")
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
