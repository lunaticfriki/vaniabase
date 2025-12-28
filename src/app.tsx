import { Router } from 'preact-router';
import { useEffect } from 'preact/hooks';
import { Layout } from './presentation/components/Layout';
import { createLazy } from './presentation/components/LazyLoad';
import { LandingPage } from './presentation/pages/LandingPage';
import { container } from './infrastructure/di/container';
import { AuthService } from './application/auth/AuthService';

export const Home = createLazy(() => import('./presentation/pages/Home').then(m => m.Home));
export const Collection = createLazy(() => import('./presentation/pages/Collection').then(m => m.Collection));
export const Categories = createLazy(() => import('./presentation/pages/Categories').then(m => m.Categories));
export const Tags = createLazy(() => import('./presentation/pages/Tags').then(m => m.Tags));
export const ItemDetail = createLazy(() => import('./presentation/pages/ItemDetail').then(m => m.ItemDetail));
export const About = createLazy(() => import('./presentation/pages/About').then(m => m.About));
export const CreateItem = createLazy(() => import('./presentation/pages/CreateItem').then(m => m.CreateItem));
export const Search = createLazy(() => import('./presentation/pages/Search').then(m => m.Search));
export const Topics = createLazy(() => import('./presentation/pages/Topics').then(m => m.Topics));
export const Formats = createLazy(() => import('./presentation/pages/Formats').then(m => m.Formats));

export function App() {
  useEffect(() => {
    Home.preload();
    Collection.preload();
    Categories.preload();
    Tags.preload();
    ItemDetail.preload();
    About.preload();
    CreateItem.preload();
    Search.preload();
    Topics.preload();
    Formats.preload();
  }, []);

  const authService = container.get(AuthService);

  return (
    <Layout>
      <Router>
        {authService.currentUser.value && <Home.Component path="/" />}
        {authService.currentUser.value && <Collection.Component path="/collection" />}
        {authService.currentUser.value && <Categories.Component path="/categories/:categoryName?" />}
        {authService.currentUser.value && <Tags.Component path="/tags/:tagName?" />}
        {authService.currentUser.value && <ItemDetail.Component path="/item/:id" />}
        {authService.currentUser.value && <About.Component path="/about" />}
        {authService.currentUser.value && <CreateItem.Component path="/create" />}
        {authService.currentUser.value && <Search.Component path="/search" />}
        {authService.currentUser.value && <Topics.Component path="/topics/:topicName?" />}
        {authService.currentUser.value && <Formats.Component path="/formats/:formatName?" />}
        {!authService.currentUser.value && <LandingPage path="/:rest*" />}
      </Router>
    </Layout>
  );
}
