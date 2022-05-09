import React, { useState, useContext } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/router'

// CONTEXT
import { AuthContext } from '../../../context/AuthContext'

// STYLES
import styled from '@emotion/styled'
import { device, bggradient, transition } from '../../../styles/utils'

// TEMPLATES
import Navigation from '../navigation'
import { MenuButton } from '../../common/menuButton'
import { MenuIcon } from '../../common/icons'

const Header = () => {
  const { user } = useContext(AuthContext)
  const router = useRouter()
  const [showMenu, setShowMenu] = useState(false)

  return (
    <HeaderStyled>
      <Link href="/" passHref>
        <HeaderTitle>Vaniabase</HeaderTitle>
      </Link>
      {router.pathname !== '/auth/signup' && router.pathname !== '/auth/login' && (
        <>
          <MenuButton onClick={() => setShowMenu(true)}>
            <MenuIcon />
          </MenuButton>
          {user && <Navigation showMenu={showMenu} setShowMenu={setShowMenu} />}
        </>
      )}
    </HeaderStyled>
  )
}

export default Header

const HeaderStyled = styled.header`
  display: grid;
  grid-template-columns: 1fr auto;
  place-content: center;
  background-color: transparent;
  z-index: 10;

  button {
    display: flex;
  }

  ${device.md`
    display: flex;
    justify-content: space-between;
    align-items: center;

    button {
      display: none;
    }
  `}
`
const HeaderTitle = styled.h2`
  ${transition}
  ${bggradient}
  padding: 1rem;
  font-weight: 400;
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  text-shadow: 1px 20px var(--yellow);

  &:hover {
    color: var(--yellow);
    cursor: pointer;
  }
`
