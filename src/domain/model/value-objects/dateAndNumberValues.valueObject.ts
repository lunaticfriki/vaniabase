import { ValueObject } from './valueObject';

export class Created extends ValueObject<Date> {
  private constructor(value: Date) {
    super(value);
  }
  public static create(value: Date): Created {
    return new Created(value);
  }
  public static now(): Created {
    return new Created(new Date());
  }
  public static empty(): Created {
    return new Created(new Date());
  }
}

export class Completed extends ValueObject<boolean> {
  private constructor(value: boolean) {
    super(value);
  }
  public static create(value: boolean): Completed {
    return new Completed(value);
  }
  public static notCompleted(): Completed {
    return new Completed(false);
  }
  public static empty(): Completed {
    return new Completed(false);
  }
}

export class Year extends ValueObject<number> {
  private constructor(value: number) {
    super(value);
  }
  public static create(value: number): Year {
    return new Year(value);
  }
  public static empty(): Year {
    return new Year(0);
  }
}


