import { css, keyframes } from '@emotion/react'
import styled from '@emotion/styled'

const colors = css`
  --black: #000;
  --white: #fff;
  --gray: #cfcccf;
  --pink: #cc004e;
  --yellow: #e6f977;
  --dark_blue: #0f090f;
  --secondary_white: #f4f4f4;
  --blur: rgba(0, 0, 0, 0.8);
`

const sizes = {
  sm: '500px',
  md: '769px',
  lg: '972px',
  xl: '1200px',
}

const device = Object.keys(sizes).reduce((acc, label) => {
  acc[label] = (...args) => css`
    @media (min-width: ${sizes[label]}) {
      ${css(...args)};
    }
  `
  return acc
}, {})

const transition = css`
  transition: 0.3s all ease-in-out;
`
const globalStyle = css`
  :root {
    ${colors}
  }
  * {
    box-sizing: border-box;
    padding: 0;
    margin: 0;
  }
  html,
  body {
    font-family: Tomorrow, sans-serif;
    font-size: 16px;
    line-height: 1.5;
    background-color: var(--dark_blue);
  }
  main,
  footer {
    z-index: 2;
  }
  h1,
  h2 {
    font-weight: 100;
    text-transform: uppercase;
  }
  a {
    ${transition};
    color: var(--pink);
    text-decoration: none;

    &:visited {
      color: var(--pink);
    }
    &:hover {
      color: var(--yellow);
    }
  }
`
const LayoutStyled = styled.div`
  min-height: 100vh;
  display: grid;
  grid-template-rows: 5rem 1fr 10rem;
  background: url('/images/pattern.jpg') no-repeat fixed;
  background-size: cover;
  color: var(--secondary_white);
  position: relative;

  &:before {
    position: absolute;
    content: '';
    width: 100%;
    height: 100%;
    background-color: var(--blur);
    border-radius: 5px;
    margin: auto;
  }
`

const fadeIn = keyframes`
0% {
  opacity: 0;
}
100% {
  opacity: 1;
}
`

const bggradient = css`
  background: linear-gradient(
    90deg,
    rgba(210, 4, 98, 1) 0%,
    rgba(121, 9, 117, 1) 35%,
    rgba(136, 7, 53, 1) 100%
  );
`

export { colors, sizes, device, globalStyle, LayoutStyled, transition, fadeIn, bggradient }
