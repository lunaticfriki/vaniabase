import { Id } from '../value-objects/id.valueObject';
import {
  Title,
  Description,
  Author,
  Cover,
  Owner,
  Topic,
  Format,
  Publisher,
  Language
} from '../value-objects/stringValues.valueObject';
import { Tags } from '../value-objects/tags.valueObject';
import { Created, Completed, Year } from '../value-objects/dateAndNumberValues.valueObject';
import { Category } from './category.entity';

export class Item {
  private constructor(
    public readonly id: Id,
    public readonly title: Title,
    public readonly description: Description,
    public readonly author: Author,
    public readonly cover: Cover,
    public readonly owner: Owner,
    public readonly tags: Tags,
    public readonly topic: Topic,
    public readonly format: Format,
    public readonly created: Created,
    public readonly completed: Completed,
    public readonly year: Year,
    public readonly publisher: Publisher,
    public readonly language: Language,
    public readonly category: Category
  ) {}

  public static create(props: {
    id: Id;
    title: Title;
    description: Description;
    author: Author;
    cover: Cover;
    owner: Owner;
    tags: Tags;
    topic: Topic;
    format: Format;
    created: Created;
    completed: Completed;
    year: Year;
    publisher: Publisher;
    language: Language;
    category: Category;
  }): Item {
    return new Item(
      props.id,
      props.title,
      props.description,
      props.author,
      props.cover,
      props.owner,
      props.tags,
      props.topic,
      props.format,
      props.created,
      props.completed,
      props.year,
      props.publisher,
      props.language,
      props.category
    );
  }

  public static empty(): Item {
    return new Item(
      Id.empty(),
      Title.empty(),
      Description.empty(),
      Author.empty(),
      Cover.empty(),
      Owner.empty(),
      Tags.empty(),
      Topic.empty(),
      Format.empty(),
      Created.empty(),
      Completed.empty(),
      Year.empty(),
      Publisher.empty(),
      Language.empty(),
      Category.empty()
    );
  }
  public static isEditable(
    initial: {
      title: string;
      description: string;
      author: string;
      cover: string;
      tags: string;
      topic: string;
      format: string;
      completed: boolean;
      year: string;
      publisher: string;
      language: string;
      category: string;
    },
    current: {
      title: string;
      description: string;
      author: string;
      cover: string;
      tags: string;
      topic: string;
      format: string;
      completed: boolean;
      year: string;
      publisher: string;
      language: string;
      category: string;
    }
  ): boolean {
    return (
      initial.title !== current.title ||
      initial.description !== current.description ||
      initial.author !== current.author ||
      initial.cover !== current.cover ||
      initial.tags !== current.tags ||
      initial.topic !== current.topic ||
      initial.format !== current.format ||
      initial.completed !== current.completed ||
      initial.year !== current.year ||
      initial.publisher !== current.publisher ||
      initial.language !== current.language ||
      initial.category !== current.category
    );
  }
}
