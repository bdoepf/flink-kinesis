package de.bdoepf

case class Even(even: Boolean) {
  override def toString: String = s"isEven=$even"
}
