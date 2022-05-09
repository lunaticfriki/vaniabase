import { useContext, useState } from 'react'

// CONTEXT
import { AuthContext } from '../../context/AuthContext'

// TEMPLATES
import Layout from '../../components/layouts'
import {
  AuthStyled,
  AuthTitle,
  Form,
  FormErrorMessage,
  Input,
  InputStyled,
  TextareaStyled,
  Textarea,
  Select,
} from '../../components/common/form'

// VALIDATION
import useValidation from '../../hooks/useValidation'
import { NEW_ITEM_INITIAL_STATE } from '../../utils'
import { newItemValidation } from '../../validations'
import { API_URL } from '../../config'
import { parseCookies } from '../../helpers'

const NewItem = ({ token }) => {
  const { user } = useContext(AuthContext)
  const [submitError, setSubmitError] = useState('')

  const addItem = async () => {
    const newItem = {
      data: {
        author,
        category,
        description,
        format,
        language,
        publisher,
        tags,
        title,
        topic,
        year,
        user: user.id,
      },
    }

    try {
      const res = await fetch(`${API_URL}/items`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(newItem),
      })
      if (!res.ok) {
        setSubmitError('Something went wrong')
      } else {
        // TODO: Add success message
        setValues(NEW_ITEM_INITIAL_STATE)
      }
    } catch (error) {
      console.log(error.message)
      setSubmitError(error.message)
    }
  }

  const { errors, values, setValues, handleChange, handleSubmit } = useValidation(
    NEW_ITEM_INITIAL_STATE,
    newItemValidation,
    addItem
  )

  const { author, category, description, format, language, publisher, tags, title, topic, year } =
    values

  return (
    <Layout>
      <AuthStyled>
        <AuthTitle>New Item</AuthTitle>
        <Form onSubmit={handleSubmit} noValidate>
          <InputStyled error={errors.title}>
            <Input
              type="text"
              id="title"
              name="title"
              placeholder="Title"
              value={title}
              onChange={handleChange}
              error={errors.title}
            />
            {errors.title && <FormErrorMessage>{errors.title}</FormErrorMessage>}
          </InputStyled>

          <InputStyled>
            <Input
              type="text"
              id="author"
              name="author"
              placeholder="Author"
              value={author}
              onChange={handleChange}
            />
          </InputStyled>

          <InputStyled>
            <Input
              type="text"
              id="publisher"
              name="publisher"
              placeholder="Publisher"
              value={publisher}
              onChange={handleChange}
            />
          </InputStyled>

          <InputStyled>
            <Input
              type="text"
              id="format"
              name="format"
              placeholder="Format"
              value={format}
              onChange={handleChange}
            />
          </InputStyled>

          <InputStyled>
            <Input
              type="text"
              id="language"
              name="language"
              placeholder="Language"
              value={language}
              onChange={handleChange}
            />
          </InputStyled>

          <InputStyled>
            <Input
              type="text"
              id="topic"
              name="topic"
              placeholder="Topic"
              value={topic}
              onChange={handleChange}
            />
          </InputStyled>

          <InputStyled>
            <Input
              type="text"
              id="year"
              name="year"
              placeholder="Year"
              value={year}
              onChange={handleChange}
            />
          </InputStyled>

          <InputStyled error={errors.category}>
            <Select
              type="text"
              id="category"
              name="category"
              placeholder="Category"
              value={category}
              onChange={handleChange}
              error={errors.category}
            >
              <option hidden>Select an option</option>
              <option value="books">Books</option>
              <option value="music">Music</option>
              <option value="comics">Comics</option>
              <option value="videogames">Videogames</option>
              <option value="magazines">Magazines</option>
            </Select>
            {errors.category && <FormErrorMessage>{errors.category}</FormErrorMessage>}
          </InputStyled>

          <TextareaStyled>
            <Textarea
              type="text"
              id="description"
              name="description"
              placeholder="Description"
              value={description}
              onChange={handleChange}
            />
          </TextareaStyled>

          <InputStyled>
            <Input
              type="text"
              id="tags"
              name="tags"
              placeholder="Add tags (rpg, biography, cyberpunk...)"
              value={tags}
              onChange={handleChange}
            />
          </InputStyled>
          <InputStyled>
            <Input type="submit" value="Add item" error={submitError} />
            {submitError && <FormErrorMessage>{submitError}</FormErrorMessage>}
          </InputStyled>
        </Form>
      </AuthStyled>
    </Layout>
  )
}

export default NewItem

export async function getServerSideProps({ req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  return {
    props: { token },
  }
}
