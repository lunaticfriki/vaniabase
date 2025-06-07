export class Item {
  private constructor(
    private id: string,
    private title: string,
    private author: string,
    private format: string,
    private description: string,
    private imageUrl: string,
    private category: string,
    private topic: string,
    private tags: string[],
    private completed: boolean,
    private createdAt: Date,
    private updatedAt: Date,
    private owner: string
  ) {}

  static create(
    id: string,
    title: string,
    author: string,
    format: string,
    description: string,
    imageUrl: string,
    category: string,
    topic: string,
    tags: string[],
    completed: boolean,
    createdAt: Date,
    updatedAt: Date,
    owner: string
  ): Item {
    return new Item(
      id,
      title,
      author,
      format,
      description,
      imageUrl,
      category,
      topic,
      tags,
      completed,
      createdAt,
      updatedAt,
      owner
    );
  }

  static empty(): Item {
    return new Item(
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      [],
      false,
      new Date(),
      new Date(),
      ''
    );
  }
}
