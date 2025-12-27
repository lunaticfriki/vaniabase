export abstract class ValueObject<T> {
  protected constructor(public readonly value: T) {}

  public equals(other: ValueObject<T>): boolean {
    if (other === null || other === undefined) {
      return false;
    }
    if (other.constructor.name !== this.constructor.name) {
      return false;
    }
    return this.value === other.value;
  }
}
