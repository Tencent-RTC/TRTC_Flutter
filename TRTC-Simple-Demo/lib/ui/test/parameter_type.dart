


enum ParameterType {
  string,
  int,
  double,
  bool,
  tClass,
  tEnum,
}

class Parameter {
  String name;
  ParameterType type;
  dynamic value;

  Parameter({
    required this.name,
    required this.type,
    required this.value
  });
}