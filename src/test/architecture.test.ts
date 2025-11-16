import { filesOfProject } from 'tsarch';
import { globSync } from 'glob';

describe('Architecture Tests', () => {
  const projectFiles = filesOfProject('tsconfig.app.json');

  const LAYERS = {
    DOMAIN: 'domain',
    INFRASTRUCTURE: 'infrastructure',
    APP: 'app',
    PRESENTATION: 'presentation',
  };

  const PRESENTATION_FOLDERS = [
    'components',
    'containers',
    'skeletons',
    'pages',
    'errors',
  ];

  describe('Hexagonal Architecture - Layer Dependencies', () => {
    it('domain layer should not import from infrastructure', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.DOMAIN)
        .shouldNot()
        .dependOnFiles()
        .inFolder(LAYERS.INFRASTRUCTURE);

      await rule.check();
    });

    it('domain layer should not import from app', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.DOMAIN)
        .shouldNot()
        .dependOnFiles()
        .inFolder(LAYERS.APP);

      await rule.check();
    });

    it('domain layer should not import from presentation', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.DOMAIN)
        .shouldNot()
        .dependOnFiles()
        .inFolder(LAYERS.PRESENTATION);

      await rule.check();
    });

    it('infrastructure layer should not import from app', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.INFRASTRUCTURE)
        .shouldNot()
        .dependOnFiles()
        .inFolder(LAYERS.APP);

      await rule.check();
    });

    it('infrastructure layer should not import from presentation', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.INFRASTRUCTURE)
        .shouldNot()
        .dependOnFiles()
        .inFolder(LAYERS.PRESENTATION);

      await rule.check();
    });

    it('app layer should not import from presentation', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.APP)
        .shouldNot()
        .dependOnFiles()
        .inFolder(LAYERS.PRESENTATION);

      await rule.check();
    });
  });

  describe('Presentation Layer - Folder Structure', () => {
    it('presentation layer should only contain allowed folders', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.PRESENTATION)
        .should()
        .matchPattern(
          `^src/${LAYERS.PRESENTATION}/(${PRESENTATION_FOLDERS.join(
            '|'
          )})/.*\\.(tsx?|css)$`
        );

      await rule.check();
    });
  });

  describe('Presentation Layer - Naming Conventions', () => {
    it('all .tsx files in components/ should end with .component.tsx', () => {
      const files = globSync('src/presentation/components/**/*.tsx');
      const invalidFiles = files.filter(
        (file) => !file.endsWith('.component.tsx')
      );

      expect(invalidFiles).toEqual([]);
    });

    it('all .tsx files in containers/ should end with .container.tsx', () => {
      const files = globSync('src/presentation/containers/**/*.tsx');
      const invalidFiles = files.filter(
        (file) => !file.endsWith('.container.tsx')
      );

      expect(invalidFiles).toEqual([]);
    });

    it('all .tsx files in skeletons/ should end with .skeleton.tsx', () => {
      const files = globSync('src/presentation/skeletons/**/*.tsx');
      const invalidFiles = files.filter(
        (file) => !file.endsWith('.skeleton.tsx')
      );

      expect(invalidFiles).toEqual([]);
    });

    it('all .tsx files in pages/ should end with .page.tsx', () => {
      const files = globSync('src/presentation/pages/**/*.tsx');
      const invalidFiles = files.filter((file) => !file.endsWith('.page.tsx'));

      expect(invalidFiles).toEqual([]);
    });

    it('all .tsx files in errors/ should end with .error.tsx', () => {
      const files = globSync('src/presentation/errors/**/*.tsx');
      const invalidFiles = files.filter((file) => !file.endsWith('.error.tsx'));

      expect(invalidFiles).toEqual([]);
    });
  });

  describe('Hexagonal Architecture - Infrastructure Dependencies', () => {
    it('infrastructure should depend on domain only', async () => {
      const rule = projectFiles
        .inFolder(LAYERS.INFRASTRUCTURE)
        .should()
        .dependOnFiles()
        .inFolder(LAYERS.DOMAIN);

      await rule.check();
    });
  });
});
