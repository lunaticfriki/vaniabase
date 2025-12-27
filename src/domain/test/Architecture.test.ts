import { describe, it, expect } from 'vitest';
import { filesOfProject } from 'tsarch';

describe('Architecture Rules', () => {
  it('domain should not depend on app', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain')
      .shouldNot()
      .dependOnFiles()
      .inFolder('src/app')
      .check();
    expect(violations).toEqual([]);
  });

  it('domain should not depend on infrastructure', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain')
      .shouldNot()
      .dependOnFiles()
      .inFolder('src/infrastructure')
      .check();
    expect(violations).toEqual([]);
  });

  it('domain should not depend on presentation', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain')
      .shouldNot()
      .dependOnFiles()
      .inFolder('src/presentation')
      .check();
    expect(violations).toEqual([]);
  });

  it('domain model should not depend on seed', async () => {
       const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/model')
      .shouldNot()
      .dependOnFiles()
      .inFolder('src/domain/seed')
      .check();
       expect(violations).toEqual([]);
  });

    it('domain model should not depend on test', async () => {
       const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/model')
      .shouldNot()
      .dependOnFiles()
      .inFolder('src/domain/test')
      .check();
       expect(violations).toEqual([]);
  });
});
