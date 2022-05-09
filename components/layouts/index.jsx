import Head from 'next/head'
import { css, Global } from '@emotion/react'
import { useRouter } from 'next/router'
import { globalStyle, LayoutStyled } from '../../styles/utils'
import Footer from '../ui/footer'
import Header from '../ui/header'

const Layout = ({ children, title = '' }) => {
  const router = useRouter()

  return (
    <LayoutStyled>
      <Global
        styles={css`
          ${globalStyle}
        `}
      />
      <Head>
        <title>Vaniabase {title}</title>
      </Head>
      <Header />
      <main>{children}</main>
      {router.asPath === '/' && <Footer />}
    </LayoutStyled>
  )
}

export default Layout
