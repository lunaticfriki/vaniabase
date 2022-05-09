import styled from '@emotion/styled'

const Footer = () => {
  const year = new Date().getFullYear()
  return (
    <FooterStyled>
      <em>
        @lunaticfriki, <span>{year}</span>
      </em>
    </FooterStyled>
  )
}

export default Footer

const FooterStyled = styled.footer`
  width: 100%;
  display: grid;
  place-content: center;
  place-items: center;
  font-size: clamp(0.7rem, 2vw, 0.9rem);

  span {
    color: var(--pink);
    font-style: normal;
  }
`
