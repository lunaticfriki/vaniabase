export interface IItem {
  id: string;
  name: string;
  author: string;
  description: string;
  imageUrl: string;
  topic: string;
  tags: string[];
  owner: string;
  completed: boolean;
  year: string;
  language: string;
  format: string;
  category: string;
}

export class Item {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly author: string,
    public readonly description: string,
    public readonly imageUrl: string,
    public readonly topic: string,
    public readonly tags: string[],
    public readonly owner: string,
    public readonly completed: boolean,
    public readonly year: string,
    public readonly language: string,
    public readonly format: string,
    public readonly category: string
  ) {}

  static create(props: Omit<Item, 'id'>, id?: string): Item {
    return new Item(
      id ?? crypto.randomUUID(),
      props.name,
      props.author,
      props.description,
      props.imageUrl,
      props.topic,
      props.tags,
      props.owner,
      props.completed,
      props.year,
      props.language,
      props.format,
      props.category
    );
  }

  static empty(): Item {
    return new Item('', '', '', '', '', '', [], '', false, '', '', '', '');
  }

  static fromJson(json: IItem): Item {
    return new Item(
      json.id,
      json.name,
      json.author,
      json.description,
      json.imageUrl,
      json.topic,
      json.tags,
      json.owner,
      json.completed,
      json.year,
      json.language,
      json.format,
      json.category
    );
  }

  static toJson(item: Item): IItem {
    return {
      id: item.id,
      name: item.name,
      author: item.author,
      description: item.description,
      imageUrl: item.imageUrl,
      topic: item.topic,
      tags: item.tags,
      owner: item.owner,
      completed: item.completed,
      year: item.year,
      language: item.language,
      format: item.format,
      category: item.category,
    };
  }

  update(item: Item, props: Partial<Omit<Item, 'id'>>): Item {
    return new Item(
      item.id,
      props.name ?? item.name,
      props.author ?? item.author,
      props.description ?? item.description,
      props.imageUrl ?? item.imageUrl,
      props.topic ?? item.topic,
      props.tags ?? item.tags,
      props.owner ?? item.owner,
      props.completed ?? item.completed,
      props.year ?? item.year,
      props.language ?? item.language,
      props.format ?? item.format,
      props.category ?? item.category
    );
  }

  getLabel(): string {
    return `${this.name} - (${this.author})`;
  }

  markAsCompleted(): Item {
    return new Item(
      this.id,
      this.name,
      this.author,
      this.description,
      this.imageUrl,
      this.topic,
      this.tags,
      this.owner,
      true,
      this.year,
      this.language,
      this.format,
      this.category
    );
  }

  toggleComplete(): Item {
    return new Item(
      this.id,
      this.name,
      this.author,
      this.description,
      this.imageUrl,
      this.topic,
      this.tags,
      this.owner,
      !this.completed,
      this.year,
      this.language,
      this.format,
      this.category
    );
  }
}
