abstract class BaseClass {
  String get testField;
}

/// This is the docstring for [TestClass]
class TestClass extends BaseClass {
  @override
  final String testField;

  /// This is the docstring for the constructor.
  TestClass({
    required this.testField,
  });
}

void main(List<String> args) {
  TestClass testClass = TestClass(testField: "testField");
  print(testClass);
}
