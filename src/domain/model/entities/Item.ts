import { Id } from '../value-objects/Id';
import { Title, Description, Author, Cover, Owner, Topic, Format, Publisher, Language } from '../value-objects/StringValues';
import { Tags } from '../value-objects/Tags';
import { Created, Completed, Year } from '../value-objects/DateAndNumberValues';
import { Category } from './Category';

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

  public static create(
    id: Id,
    title: Title,
    description: Description,
    author: Author,
    cover: Cover,
    owner: Owner,
    tags: Tags,
    topic: Topic,
    format: Format,
    created: Created,
    completed: Completed,
    year: Year,
    publisher: Publisher,
    language: Language,
    category: Category
  ): Item {
    return new Item(
      id,
      title,
      description,
      author,
      cover,
      owner,
      tags,
      topic,
      format,
      created,
      completed,
      year,
      publisher,
      language,
      category
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
}
