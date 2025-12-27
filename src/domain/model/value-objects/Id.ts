import { v4 as uuidv4 } from 'uuid';
import { ValueObject } from './ValueObject';

export class Id extends ValueObject<string> {
  private constructor(value: string) {
    super(value);
  }

  public static create(value: string): Id {
    return new Id(value);
  }

  public static random(): Id {
    return new Id(uuidv4());
  }
}
