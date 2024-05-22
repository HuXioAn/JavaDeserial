/**
 * @brief identify the deserialization package used in the java project
 * @name idDeserial
 * @kind problem
 * @problem.severity warning
 * @id codeql/deserial/iddeserial
 */
import java
import semmle.code.java.dataflow.DataFlow

/**
 * A class representing a deserialization method.
 */
class DeserializationMethod extends Method {
  DeserializationMethod() {
    (this.getDeclaringType().hasQualifiedName("java.io", "ObjectInputStream") and this.hasName("readObject"))
    or (this.getDeclaringType().hasQualifiedName("org.apache.commons.lang3", "SerializationUtils") and this.hasName("deserialize"))
    or (this.getDeclaringType().hasQualifiedName("com.thoughtworks.xstream", "XStream") and this.hasName("fromXML"))
    or (this.getDeclaringType().hasQualifiedName("com.esotericsoftware.kryo", "Kryo") and this.hasName("readClassAndObject"))
    or (this.getDeclaringType().hasQualifiedName("com.caucho.hessian.io", "HessianInput") and this.hasName("readObject"))
    or (this.getDeclaringType().hasQualifiedName("com.fasterxml.jackson.databind", "ObjectMapper") and this.hasName("readValue"))
    or (this.getDeclaringType().hasQualifiedName("com.google.gson", "Gson") and this.hasName("fromJson"))
    or (this.getDeclaringType().hasQualifiedName("org.yaml.snakeyaml", "Yaml") and this.hasName("load"))
  }
}

/**
 * A class representing a call to a deserialization method.
 */
class DeserializationCall extends MethodCall {
  DeserializationCall() {
    this.getMethod() instanceof DeserializationMethod
  }
}


from DeserializationCall call//, string pkgName, int callCount
// where call.getMethod().getDeclaringType().getQualifiedName().toString() = pkgName
//     and count(string i | call.getMethod().getDeclaringType().getQualifiedName() = i | call ) = callCount

// //select pkgName, count( string i | call.getMethod().getDeclaringType().getQualifiedName().toString() = i | call ).toString()
select call, "Deserialization method called: " + call.getMethod().getDeclaringType().getQualifiedName() + "." + call.getMethod().getName()



