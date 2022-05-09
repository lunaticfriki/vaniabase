import React, { useContext, useState } from 'react'
import { useRouter } from 'next/router'
import Link from 'next/link'

// CONTEXT
import { AuthContext } from '../../../context/AuthContext'

// STYLES
import styled from '@emotion/styled'
import { bggradient, device, fadeIn, transition } from '../../../styles/utils'

// TEMPLATES
import {
  AddIcon,
  AllItemsIcon,
  CategoriesIcon,
  CloseIcon,
  HomeIcon,
  InfoIcon,
  LogoutIcon,
  SearchIcon,
  UserIcon,
} from '../../common/icons'
import { MenuButton } from '../../common/menuButton'
import { Input, SearchInputContainer } from '../../common/form'

const Navigation = ({ showMenu, setShowMenu }) => {
  const { user, logout } = useContext(AuthContext)
  const [showInputSearch, setShowInputSearch] = useState(false)
  const [term, setTerm] = useState('')

  const router = useRouter()

  const signOut = () => {
    logout()
  }

  const handleChange = (e) => {
    setTerm(e.target.value)
  }

  const handleKeyPress = (event, term) => {
    if (event.keyCode == 13) {
      setTerm('')
      setShowInputSearch(false)
      router.push(`/items/search?term=${term}&page=1`)
    }
  }

  const handleSearch = () => {
    setShowInputSearch(false)
    router.push(`/items/search?term=${term}&page=1`)
  }

  return (
    <NavigationStyled showMenu={showMenu}>
      <NavigationHeader>
        <MenuButton onClick={() => setShowMenu(false)}>
          <CloseIcon />
        </MenuButton>
      </NavigationHeader>
      <NavigationList>
        {user && (
          <DisplayName>
            Hello, <span>{user.username}</span>
          </DisplayName>
        )}
        <Link href="/" passHref>
          <NavigationElement>
            <HomeIcon />
            <NavigationElementLabel>Home</NavigationElementLabel>
          </NavigationElement>
        </Link>
        <Link href="/categories" passHref>
          <NavigationElement>
            <CategoriesIcon />
            <NavigationElementLabel>Categories</NavigationElementLabel>
          </NavigationElement>
        </Link>
        {showInputSearch && (
          <SearchInputContainer>
            <Input
              name="term"
              value={term}
              onChange={handleChange}
              onKeyDown={(e) => handleKeyPress(e, term)}
              autoFocus={showInputSearch}
            />
            <p onClick={handleSearch}>Search</p>
          </SearchInputContainer>
        )}
        <NavigationElement onClick={() => setShowInputSearch(!showInputSearch)}>
          <SearchIcon />
          <NavigationElementLabel>Search</NavigationElementLabel>
        </NavigationElement>
        <Link href="/items/all?page=1" passHref>
          <NavigationElement>
            <AllItemsIcon />
            <NavigationElementLabel>All items</NavigationElementLabel>
          </NavigationElement>
        </Link>
        <Link href="/items/new-item" passHref>
          <NavigationElement>
            <AddIcon />
            <NavigationElementLabel>Add new item</NavigationElementLabel>
          </NavigationElement>
        </Link>
        <Link href="/about" passHref>
          <NavigationElement>
            <InfoIcon />
            <NavigationElementLabel>About</NavigationElementLabel>
          </NavigationElement>
        </Link>
        {/*<NavigationElement>*/}
        {/*  <UserIcon />*/}
        {/*  <NavigationElementLabel>Account</NavigationElementLabel>*/}
        {/*</NavigationElement>*/}
        <NavigationElement onClick={signOut}>
          <LogoutIcon />
          <NavigationElementLabel>Logout</NavigationElementLabel>
        </NavigationElement>
      </NavigationList>
    </NavigationStyled>
  )
}

export default Navigation

const NavigationStyled = styled.nav`
  display: ${({ showMenu }) => (showMenu ? 'grid' : 'none')};
  grid-template-rows: 5rem 1fr;
  width: 100%;
  height: 100%;
  position: fixed;
  top: 0;
  right: 0;
  animation: ${fadeIn} 0.4s ease-in-out;
  background-color: var(--dark_blue);

  ${device.md`
    display: flex;
    flex-direction: row;
    width: auto;
    height: auto;
    position: unset;
    background: unset;
    animation: unset;
  `};
`
const NavigationHeader = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: flex-end;

  ${device.md`
    display: none;
  `};
`
const NavigationList = styled.ul`
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  justify-content: center;
  list-style: none;
  padding: 1rem;

  ${device.md`
    flex-direction: row;
    align-items: center;
  `};
`
const NavigationElement = styled.li`
  ${transition};

  display: flex;
  align-items: center;
  padding: 0.5rem;
  font-size: 1.2rem;
  //background-clip: text;
  //-webkit-background-clip: text;
  //-webkit-text-fill-color: transparent;

  svg {
    ${transition};
    
    color: var(--pink);
    
    ${device.md`
      color: var(--secondary_white);
    `}

  &:hover {
    cursor: pointer;
    color: var(--yellow);

    ${device.md`
      color: var(--pink);
    `}
  }

  ${device.md`
    font-size: 1.5rem;
  `};
`
const NavigationElementLabel = styled.p`
  margin-inline-start: 1rem;
  font-size: 1.5rem;

  ${device.md`
    display: none;
  `}
`
const DisplayName = styled.p`
  margin-inline-end: 0.5rem;

  span {
    color: var(--yellow);
  }
`
