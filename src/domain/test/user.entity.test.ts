import { describe, it, expect } from 'vitest';
import { UserMother } from './user.mother.ts';
import { Id } from '../model/value-objects/id.valueObject';

describe('User Entity', () => {
  it('should create a valid user', () => {
    const user = UserMother.create('user-1', 'Vania', 'vania@example.com', 'avatar-url');

    expect(user.id.value).toBe('user-1');
    expect(user.name).toBe('Vania');
    expect(user.email).toBe('vania@example.com');
    expect(user.avatar).toBe('avatar-url');
  });

  it('should create an empty user', () => {
    const emptyUser = UserMother.empty();

    expect(emptyUser.id).toBeInstanceOf(Id);
    expect(emptyUser.name).toBe('');
    expect(emptyUser.email).toBe('');
    expect(emptyUser.avatar).toBe('');
  });

  it('should create a random user', () => {
    const user = UserMother.random();

    expect(user.id).toBeDefined();
    expect(user.name).toBeDefined();
    expect(user.email).toBeDefined();
    expect(user.avatar).toBeDefined();
  });
});
