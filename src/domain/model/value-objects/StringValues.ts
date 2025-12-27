import { ValueObject } from './ValueObject';

export class Title extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Title { return new Title(value); }
}

export class Description extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Description { return new Description(value); }
}

export class Author extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Author { return new Author(value); }
}

export class Cover extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Cover { return new Cover(value); }
}

export class Owner extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Owner { return new Owner(value); }
}

export class Topic extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Topic { return new Topic(value); }
}

export class Format extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Format { return new Format(value); }
}

export class Publisher extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Publisher { return new Publisher(value); }
}

export class Language extends ValueObject<string> {
  private constructor(value: string) { super(value); }
  public static create(value: string): Language { return new Language(value); }
}
