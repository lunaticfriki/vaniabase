import styled from '@emotion/styled'
import Layout from '../components/layouts'

const ErrorPage = () => {
  return (
    <Layout title="| Not found">
      <ErrorPageStyled>
        <h3>ERROR 404</h3>
        <h1>Ups, sorry, we didn't found what you were looking for</h1>
      </ErrorPageStyled>
    </Layout>
  )
}

export default ErrorPage

const ErrorPageStyled = styled.div`
  height: 100%;
  display: grid;
  place-items: center;
  place-content: center;

  h3 {
    color: var(--pink);
  }
`
