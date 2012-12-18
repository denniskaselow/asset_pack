
class LintItem {
  final int lineNumber;
  final String details;
  String toString() => '$lineNumber: $details';

  LintItem(this.lineNumber, this.details);
}

class PackLinter {
  final List<LintItem> issues = new List<LintItem>();

  void lint(String filename) {
    // Implement linter.
  }

  void report() {
    issues.forEach((issue) {
      print('$issue');
    });
  }
}


main() {
  var linter = new PackLinter();
  linter.lint('filename.txt');
  linter.report();
}