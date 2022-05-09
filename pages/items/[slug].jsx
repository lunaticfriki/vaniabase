import Link from 'next/link'
import { useRouter } from 'next/router'
import styled from '@emotion/styled'
import { parseCookies } from '../../helpers'
import { API_URL } from '../../config'
import { BackButton } from '../../components/common/backButton'
import { ArrowBackIcon, DeleteIcon, EditIcon } from '../../components/common/icons'
import Layout from '../../components/layouts'
import { device, bggradient, transition } from '../../styles/utils'

const ItemPage = ({ item, token }) => {
  const router = useRouter()

  const deleteItem = async () => {
    // TODO: Add custom confirm modal
    if (confirm('are you sure?')) {
      const res = await fetch(`${API_URL}/items/${item[0].id}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      const data = await res.json()

      if (!res.ok) {
        console.log('ERROR', data.message)
      } else {
        await router.push('/')
      }
    }
  }

  const {
    title,
    author,
    image,
    publisher,
    description,
    tags,
    language,
    topic,
    year,
    format,
    category,
  } = item[0]?.attributes

  return (
    <Layout>
      <Section image={image.data?.attributes.url}>
        <ItemContainer>
          <ItemTitleContainer>
            <ItemTitle>{title}</ItemTitle>
          </ItemTitleContainer>
          <ItemSubtitle>
            Category: <span>{category}</span>
          </ItemSubtitle>
          <ItemImage
            src={image.data?.attributes.url ? image.data?.attributes.url : '/images/not_found.png'}
            alt={title}
          />
          <InfoContainer>
            <ItemElement>
              <span>Author:</span> {author}
            </ItemElement>
            <ItemElement>
              <span>Publisher:</span> {publisher}
            </ItemElement>
            <ItemElement>
              <span>Language:</span> {language}
            </ItemElement>
            <ItemElement>
              <span>Topic:</span> {topic}
            </ItemElement>
            <ItemElement>
              <span>Format:</span> {format}
            </ItemElement>
            <ItemElement>
              <span>Year:</span> {year}
            </ItemElement>
            <ItemElement>
              <span>Description: </span>
              {description}
            </ItemElement>
            <ItemTagsContainer>
              <BackButton onClick={() => router.back()}>
                <ArrowBackIcon />
              </BackButton>
              {tags.length > 1 &&
                tags.split(',').map((tag) => (
                  <p key={tag} onClick={() => router.push(`/items/search?term=${tag}&page=1`)}>
                    {tag}
                  </p>
                ))}
              <IconContainer onClick={() => deleteItem()}>
                <DeleteIcon />
              </IconContainer>
              <Link href={`/items/edit/${item[0].id}`}>
                <IconContainer>
                  <EditIcon />
                </IconContainer>
              </Link>
            </ItemTagsContainer>
          </InfoContainer>
        </ItemContainer>
      </Section>
    </Layout>
  )
}

export default ItemPage

const Section = styled.div`
  position: absolute;
  width: 100%;
  min-height: 100vh;
  background-image: url(${({ image }) => (image ? image : '/images/not_found.png')});
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
  background-attachment: fixed;
  margin-block-start: -5rem;
`
const ItemContainer = styled.section`
  width: 100%;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  background-color: var(--blur);
`
const ItemTitleContainer = styled.div`
  ${bggradient};

  min-width: 90%;
  height: 4rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--secondary-white);
  border-radius: 5px;
  text-align: center;
  margin: 8rem auto 2rem;
  position: relative;

  :before {
    position: absolute;
    content: '';
    width: 99%;
    height: 90%;
    background-color: var(--dark_blue);
    border-radius: 5px;
    margin: auto;
  }

  ${device.md`
    min-width: 500px;
    `}
`
const IconContainer = styled.div`
  ${transition};

  color: var(--secondary_white);
  font-size: 1.5rem;
  cursor: pointer;
  margin: 0 0.5rem;

  &:hover {
    color: var(--pink);
  }
`
const ItemTitle = styled.h2`
  font-size: clamp(1rem, 3vw, 1.2rem);
  z-index: 2;
`
const ItemSubtitle = styled.h4`
  text-transform: uppercase;
  font-weight: 100;

  span {
    color: var(--yellow);
    padding-inline-start: 0.5rem;
  }
`
const ItemImage = styled.img`
  width: 90%;
  border-radius: 5px;
  margin: 1rem auto;

  ${device.md`
    max-width: 500px;
  `}
`
const InfoContainer = styled.div`
  width: 90%;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  margin: 0 auto 2rem;

  ${device.xl`
    width: 60%;
  `}
`
const ItemElement = styled.p`
  margin: 0.25rem 0;
  text-transform: capitalize;

  &:last-of-type {
    text-transform: unset;
  }

  span {
    color: var(--pink);
    padding-inline-end: 0.25rem;
  }
`
const ItemTagsContainer = styled.div`
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
  align-items: center;
  margin-block-start: 1rem;

  p {
    ${transition};

    text-align: center;
    text-transform: uppercase;
    color: var(--yellow);
    border-radius: 5px;
    margin: 0.25rem;
    font-size: 0.7rem;
    padding: 0.5rem;

    &:hover {
      cursor: pointer;
      color: var(--pink);
    }

    ${device.md`
      font-size: 0.8rem;
    `}
  }
`

export async function getServerSideProps({ params, req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const res = await fetch(`${API_URL}/items?filters[slug]=${params.slug}&populate=*`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })
  const { data } = await res.json()

  if (data.length < 1) {
    return {
      redirect: {
        destination: '/',
        permanent: false,
      },
    }
  }

  return {
    props: { item: data, token },
  }
}
