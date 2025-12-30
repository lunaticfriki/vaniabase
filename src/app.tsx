import { Router } from 'preact-router';
import { useEffect } from 'preact/hooks';
import { Layout } from './presentation/components/layout.component';
import { createLazy } from './presentation/components/lazyLoad.component';
import { Login } from './presentation/pages/login.page';
import { Signup } from './presentation/pages/signup.page';
import { container } from './infrastructure/di/container';
import { AuthService } from './application/auth/auth.service';

export const Home = createLazy(() => import('./presentation/pages/home.page').then(m => m.Home));
export const Collection = createLazy(() => import('./presentation/pages/collection.page').then(m => m.Collection));
export const Categories = createLazy(() => import('./presentation/pages/categories.page').then(m => m.Categories));
export const Tags = createLazy(() => import('./presentation/pages/tags.page').then(m => m.Tags));
export const ItemDetail = createLazy(() => import('./presentation/pages/itemDetail.page').then(m => m.ItemDetail));
export const About = createLazy(() => import('./presentation/pages/about.page').then(m => m.About));
export const CreateItem = createLazy(() => import('./presentation/pages/createItem.page').then(m => m.CreateItem));
export const EditItem = createLazy(() => import('./presentation/pages/editItem.page').then(m => m.EditItem));
export const Search = createLazy(() => import('./presentation/pages/search.page').then(m => m.Search));
export const Topics = createLazy(() => import('./presentation/pages/topics.page').then(m => m.Topics));
export const Formats = createLazy(() => import('./presentation/pages/formats.page').then(m => m.Formats));
export const Dashboard = createLazy(() => import('./presentation/pages/dashboard.page').then(m => m.Dashboard));
export const CompletedItems = createLazy(() =>
  import('./presentation/pages/completedItems.page').then(m => m.CompletedItems)
);

export function App() {
  useEffect(() => {
    Home.preload();
    Collection.preload();
    Categories.preload();
    Tags.preload();
    ItemDetail.preload();
    About.preload();
    CreateItem.preload();
    EditItem.preload();
    Search.preload();
    Topics.preload();
    Formats.preload();
    Dashboard.preload();
    CompletedItems.preload();
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
        {authService.currentUser.value && <EditItem.Component path="/edit/:id" />}
        {authService.currentUser.value && <Search.Component path="/search" />}
        {authService.currentUser.value && <Topics.Component path="/topics/:topicName?" />}
        {authService.currentUser.value && <Formats.Component path="/formats/:formatName?" />}
        {authService.currentUser.value && <Dashboard.Component path="/dashboard" />}
        {authService.currentUser.value && <CompletedItems.Component path="/completed" />}
        {!authService.currentUser.value && <Login path="/" />}
        {!authService.currentUser.value && <Login path="/login" />}
        {!authService.currentUser.value && <Signup path="/signup" />}
        {!authService.currentUser.value && <Login path="/:rest*" />}
      </Router>
    </Layout>
  );
}
