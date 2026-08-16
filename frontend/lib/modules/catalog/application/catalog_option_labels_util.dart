const categoryLabels = {
  'book': 'Book',
  'comic': 'Comic',
  'magazine': 'Magazine',
  'movie': 'Movie',
  'videogame': 'Videogame',
  'musicAlbum': 'Music album',
};

const formatLabels = {
  'hardcover': 'Hardcover',
  'paperback': 'Paperback',
  'ebook': 'Ebook',
  'dvd': 'DVD',
  'bluRay': 'Blu-ray',
  'vhs': 'VHS',
  'cd': 'CD',
  'vinyl': 'Vinyl',
  'cassette': 'Cassette',
  'miniDisc': 'MiniDisc',
  'cartridge': 'Cartridge',
  'digitalDownload': 'Digital download',
};

String categoryLabel(String category) => categoryLabels[category] ?? category;

String formatLabel(String format) => formatLabels[format] ?? format;
