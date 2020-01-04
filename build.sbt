name := "flink-kinesis"

version := "0.1"

scalaVersion := "2.11.12"

resolvers += Resolver.mavenLocal

val kdaVersion = "1.1.0"
val flinkVersion = "1.8.2"
// AWS Kinesis Analytics for java applications
libraryDependencies += "com.amazonaws" % "aws-kinesisanalytics-runtime" % kdaVersion
libraryDependencies += "com.amazonaws" % "aws-kinesisanalytics-flink" % kdaVersion
// Flink dependencies
libraryDependencies += "org.apache.flink" %% "flink-connector-kinesis" % flinkVersion
libraryDependencies += "org.apache.flink" %% "flink-streaming-scala" % flinkVersion % "provided"
//libraryDependencies += "org.apache.flink" %% "flink-scala" % flinkVersion
// Parquet dependencies
libraryDependencies += "org.apache.flink" % "flink-parquet" % flinkVersion
libraryDependencies += "org.apache.parquet" % "parquet-avro" % "1.10.0"

libraryDependencies += "org.apache.flink" % "flink-shaded-hadoop2" % s"2.4.1-$flinkVersion" % "test"
libraryDependencies += "org.apache.flink" % "flink-s3-fs-hadoop" % flinkVersion % "test"
libraryDependencies += "jp.co.bizreach" %% "aws-kinesis-scala" % "0.0.12" % "test"

PB.targets in Compile := Seq(
  scalapb.gen(flatPackage = true) -> (sourceManaged in Compile).value
)

assemblyMergeStrategy in assembly := {
  case "application.conf" => MergeStrategy.concat
  case "reference.conf" => MergeStrategy.concat
  case PathList("META-INF", _) => MergeStrategy.discard
  //    (xs map {
  //      _.toLowerCase
  //    }) match {
  //      case ps@(x :: xs) if ps.last.endsWith(".sf") || ps.last.endsWith(".dsa") || ps.last.endsWith(".rsa")=>
  //        MergeStrategy.discard
  //      case _ => MergeStrategy.deduplicate
  //    }
  case x => MergeStrategy.first
  //    val oldStrategy = (assemblyMergeStrategy in assembly).value
  //    oldStrategy(x)
}

mainClass in assembly := Some("de.bdoepf.FlinkS3App")
