import styled from '@emotion/styled'
import Layout from '../components/layouts'

const AboutPage = () => {
  const year = new Date().getFullYear()

  return (
    <Layout title="| About">
      <AboutPageStyled>
        <h2>Welcome to Vaniabase!</h2>
        <i>@lunaticfriki, {year}</i>
      </AboutPageStyled>
    </Layout>
  )
}

export default AboutPage

const AboutPageStyled = styled.div`
  width: 100%;
  height: 100%;
  display: grid;
  place-items: center;
  place-content: center;
`
