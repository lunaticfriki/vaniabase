import { useEffect } from 'react';
import { useItemReadService } from '../../app/item.readService';

export const HomeContainer = () => {
  const { state, actions } = useItemReadService();

  useEffect(() => {
    actions.getItems();

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (state.value.loading) {
    return <div>Loading...</div>;
  }

  return (
    <>
      <pre>{JSON.stringify(state.value.items, null, 2)}</pre>
    </>
  );
};
