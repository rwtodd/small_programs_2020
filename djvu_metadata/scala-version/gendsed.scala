package org.rwtodd.gendsed

case class BookPage(val prefix: String, val number: Option[Int]) {
   def nextPage = BookPage(prefix, number.map(_ + 1).orElse(Some(2)))
   def pageTitle = prefix + number.map(_.toString()).getOrElse("")
   val numeric = prefix.isEmpty
}

case class DjvuPage(val num: Int, val bp: BookPage) {
   def nextPage = DjvuPage(num+1, bp.nextPage)
}

case class BookMark(val title: String, val bp: BookPage)
case class ResolvedMark(val num: Int, val title: String)

object GenDsed {
  val Comments = """^\s*$|^\s*#.*$""".r
  val Metadata = """(?i)^\s*meta\s+([^:]+):\s*(.*?)\s*$""".r
  val Djvupg   = """(?i)^\s*djvu\s+(\d+)\s+(?:is|=)(?:\s+book)?\s+(\S*?)(\d*)\s*$""".r
  val Mark     = """^\s*(\S*?)(\d*)\s+(.+)$""".r

  def maybeInt(s: String): Option[Int] = 
     if (s.isEmpty) { None } else { Some(s.toInt) }

  def parseInput(lines: Iterator[String]): (Seq[DjvuPage], Seq[BookMark], Map[String,String]) = {
     val pages = scala.collection.mutable.ArrayBuffer[DjvuPage]()
     val marks = scala.collection.mutable.ArrayBuffer[BookMark]()
     val metas = scala.collection.mutable.HashMap[String,String]()
     for (l <- lines) {
        l match {
           case Comments() => {}
           case Metadata(k,v) => metas += (k -> v)
           case Djvupg(dp,pre,bp) => pages += DjvuPage(dp.toInt, BookPage(pre,maybeInt(bp)))
           case Mark(pre,bp,name) => marks += BookMark(name, BookPage(pre,maybeInt(bp)))
           case _ => throw new IllegalStateException("Bad line: " + l)
        }
     }
     (pages.toSeq, marks.toSeq, metas.toMap)
  }

  
  def forAllDjvuPages(ds: Seq[DjvuPage])(onPage: DjvuPage => Unit): Unit = 
     (ds :+ ds.last.nextPage).sliding(2).
         flatMap({ x => Seq.iterate(x(0), x(1).num - x(0).num)(_.nextPage) }).
         foreach(onPage(_))

  def main(args: Array[String]) :Unit = {
        import java.io.PrintWriter
        import java.nio.file.{Files,Paths}
        import java.nio.charset.StandardCharsets
        if (args.size != 1) {
           System.err.println("Usage: gen-dsed <file>")
           System.exit(1)
        }
        val inName = args(0)
        val (pages, marks, metas) = parseInput(scala.io.Source.fromFile(inName).getLines())
        val out = new PrintWriter(Files.newBufferedWriter(Paths.get(inName+".dsed"), StandardCharsets.UTF_8))
        val mm = new scala.collection.mutable.ArrayBuffer[ResolvedMark](marks.size)
        var remaining : scala.collection.View[BookMark] = marks.view

        System.err.println("Writing " + inName + ".dsed.")
        try {
          forAllDjvuPages(pages) { p =>
             // output the page
             out.printf("select %d; set-page-title \"%s\"%n", p.num, p.bp.pageTitle)
             // now, check if we can match any bookmarks... 
             var keepMatching = !remaining.isEmpty
             while (keepMatching) {
                 remaining.head match { 
                  case x if x.bp.numeric => {
                     mm += ResolvedMark(x.bp.number.getOrElse(0), x.title)
                     remaining = remaining.tail
                     keepMatching = !remaining.isEmpty
                  }
                  case x if x.bp == p.bp => {
                     mm += ResolvedMark(p.num, x.title)
                     remaining = remaining.tail
                     keepMatching = !remaining.isEmpty
                  }
                  case _ => keepMatching = false
                } 
             }
          }
          if (!remaining.isEmpty) {
             System.err.printf("Error: bookmark <%s> not found!%n", remaining.head.title)
             System.exit(1)
          }
          if (!metas.isEmpty) {
             out.println("select; set-meta")
             for ((k,v) <- metas) out.printf("%s\t\"%s\"%n", k, v)
             out.println(".")
          }
          if (!mm.isEmpty) {
             out.printf("select; set-outline%n(bookmarks%n")           
             for (m <- mm) out.printf("  (\"%s\" \"#%d\")%n", m.title, m.num)
             out.printf(")%n.%n")           
          }
      } finally {
          out.close()
      }
  }
}

