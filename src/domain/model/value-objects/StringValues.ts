import { ValueObject } from './ValueObject';

export class Title extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Title {
    return new Title(value);
  }
  public static empty(): Title {
    return new Title('');
  }
}

export class Description extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Description {
    return new Description(value);
  }
  public static empty(): Description {
    return new Description('');
  }
}

export class Author extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Author {
    return new Author(value);
  }
  public static empty(): Author {
    return new Author('');
  }
}

export class Cover extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Cover {
    return new Cover(value);
  }
  public static empty(): Cover {
    return new Cover('');
  }
}

export class Owner extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Owner {
    return new Owner(value);
  }
  public static empty(): Owner {
    return new Owner('');
  }
}

export class Topic extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Topic {
    return new Topic(value);
  }
  public static empty(): Topic {
    return new Topic('');
  }
}

export class Format extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Format {
    return new Format(value);
  }
  public static empty(): Format {
    return new Format('');
  }
}

export class Publisher extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Publisher {
    return new Publisher(value);
  }
  public static empty(): Publisher {
    return new Publisher('');
  }
}

export class Language extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }
  public static create(value: string): Language {
    return new Language(value);
  }
  public static empty(): Language {
    return new Language('');
  }
}
