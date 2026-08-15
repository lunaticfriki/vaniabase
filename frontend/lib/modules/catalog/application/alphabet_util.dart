const alphabetLetters = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

String letterForEntry(String entry) {
  if (entry.isEmpty) return '#';
  final first = entry[0].toUpperCase();
  return alphabetLetters.contains(first) ? first : '#';
}
