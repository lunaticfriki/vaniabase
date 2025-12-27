import { Router } from 'preact-router';
import { Layout } from './presentation/components/Layout';
import { Home } from './presentation/pages/Home';
import { Collection } from './presentation/pages/Collection';
import { About } from './presentation/pages/About';
import { ItemDetail } from './presentation/pages/ItemDetail';

export function App() {
  return (
    <Layout>
      <Router>
        <Home path="/" />
        <Collection path="/collection" />
        <ItemDetail path="/item/:id" />
        <About path="/about" />
      </Router>
    </Layout>
  );
}
