ThisBuild / scalaVersion := "2.13.1"
ThisBuild / organization := "org.rwtodd"

lazy val genDsed = (project in file("."))
  .settings(
      name := "gen-dsed"
  )


