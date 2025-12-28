import { ValueObject } from './valueObject';

export class Tags extends ValueObject<string[]> {
  private constructor(value: string[]) {
    super(value);
  }

  public static create(value: string[]): Tags {
    return new Tags(value);
  }

  public static empty(): Tags {
    return new Tags([]);
  }
}
