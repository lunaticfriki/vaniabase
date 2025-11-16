export interface IItem {
  id: string;
  name: string;
  author: string;
  description: string;
  imageUrl: string;
  topic: string;
  tags: string[];
  owner: string;
  compeleted: boolean;
  year: string;
  language: string;
  format: string;
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
    public readonly compeleted: boolean,
    public readonly year: string,
    public readonly language: string,
    public readonly format: string
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
      props.compeleted,
      props.year,
      props.language,
      props.format
    );
  }

  static empty(): Item {
    return new Item('', '', '', '', '', '', [], '', false, '', '', '');
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
      json.compeleted,
      json.year,
      json.language,
      json.format
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
      compeleted: item.compeleted,
      year: item.year,
      language: item.language,
      format: item.format,
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
      props.compeleted ?? item.compeleted,
      props.year ?? item.year,
      props.language ?? item.language,
      props.format ?? item.format
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
      this.format
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
      !this.compeleted,
      this.year,
      this.language,
      this.format
    );
  }
}
