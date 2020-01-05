package de.bdoepf

object FlinkS3AppManualTest {
  def main(args: Array[String]): Unit = {
    val region = "eu-west-1"
    val streamName = "test-stream"
    val outputPath = "output"
    FlinkS3App.run(region, streamName, outputPath)
  }
}
