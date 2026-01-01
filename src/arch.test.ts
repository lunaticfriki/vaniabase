import { describe, it, expect } from 'vitest';
import { filesOfProject } from 'tsarch';

describe('Architecture Test', () => {
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

  it('repositories should be named *.repository.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/repositories')
      .should()
      .matchPattern('.*.repository.ts')
      .check();
    expect(violations).toEqual([]);
  });

  it('services should be named *.service.ts or specific service types', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/services')
      .should()
      .matchPattern('.*.(service|readService|writeService|stateService).ts')
      .check();
    expect(violations).toEqual([]);
  });

  it('components should be named *.component.tsx', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/presentation/components')
      .should()
      .matchPattern('.*.component.tsx')
      .check();
    expect(violations).toEqual([]);
  });

  it('pages should be named *.page.tsx', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/presentation/pages')
      .should()
      .matchPattern('.*.page.tsx')
      .check();
    expect(violations).toEqual([]);
  });

  it('entities should be named *.entity.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/model/entities')
      .should()
      .matchPattern('.*.entity.ts')
      .check();
    expect(violations).toEqual([]);
  });

  it('value objects should be named *.valueObject.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/model/value-objects')
      .should()
      .matchPattern('.*.valueObject.ts')
      .check();
    expect(violations).toEqual([]);
  });

  it('view models should be named *.viewModel.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/presentation/viewModels')
      .should()
      .matchPattern('.*.viewModel.ts')
      .check();
    expect(violations).toEqual([]);
  });

  it('statistics models should be named *.model.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/model')
      .matchingPattern('.*Statistics.ts')
      .should()
      .matchPattern('.*.model.ts')
      .check();
    expect(violations).toEqual([]);
  }, 10000);

  it('mothers should be named *.mother.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/test')
      .matchingPattern('.*Mother.ts')
      .inFolder('src/domain/test')
      .matchingPattern('.*mother.ts')
      .should()
      .matchPattern('.*.mother.ts')
      .check();

    expect(violations).toEqual([]);
  });

  it('seeds should be named *.seed.ts', async () => {
    const violations = await filesOfProject('./tsconfig.app.json')
      .inFolder('src/domain/seed')
      .should()
      .matchPattern('.*.seed.ts')
      .check();
    expect(violations).toEqual([]);
  });
});
