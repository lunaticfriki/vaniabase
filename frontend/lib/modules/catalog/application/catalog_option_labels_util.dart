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
  'cd': 'CD',
  'vinyl': 'Vinyl',
  'cartridge': 'Cartridge',
  'digitalDownload': 'Digital download',
};

String categoryLabel(String category) => categoryLabels[category] ?? category;

String formatLabel(String format) => formatLabels[format] ?? format;
