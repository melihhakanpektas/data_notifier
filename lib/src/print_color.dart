/// ANSI bright foreground color codes used for debug console output.
enum PrintColor {
  black(90),
  red(91),
  green(92),
  yellow(93),
  blue(94),
  magenta(95),
  cyan(96),
  white(97);

  final int code;
  const PrintColor(this.code);
}
