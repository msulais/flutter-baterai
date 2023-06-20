extension StringManipulation on String {
    String titleCase() {
        return toLowerCase().replaceAllMapped(
            RegExp(r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
            (match) => '${match[0]![0].toUpperCase()}${match[0]!.substring(1).toLowerCase()}'
        );
    }

    String removeTrailingZeros() {
        if (contains(RegExp(r'\.')) && !contains(RegExp(r'e[\-+]'))) {
            return replaceFirstMapped(
                RegExp(r'(.+)\.(.+)'),
                (match) => '${match.group(1)!}.${match.group(2)!.replaceAll(RegExp(r'0+$'), '')}'
            ).replaceFirst(RegExp(r'\.$'), '');
        } else {
            return this;
        }
    }
}