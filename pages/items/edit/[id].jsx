import { useState, useEffect, useContext } from 'react'
import { useRouter } from 'next/router'

// CONTEXT
import { AuthContext } from '../../../context/AuthContext'

// API
import { API_URL } from '../../../config'

// TEMPLATES
import Layout from '../../../components/layouts'
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
  InputFile,
} from '../../../components/common/form'

// VALIDATION
import useValidation from '../../../hooks/useValidation'
import { newItemValidation } from '../../../validations'
import { parseCookies } from '../../../helpers'

const EditItem = ({ item, token }) => {
  const { user } = useContext(AuthContext)
  const router = useRouter()
  const [submitError, setSubmitError] = useState('')
  const [message, setMessage] = useState('')
  const [uploading, setUploading] = useState(false)
  const [image, setImage] = useState(null)

  const handleImageChange = async (e) => {
    setUploading(true)
    setImage(e.target.files[0])
  }

  useEffect(() => {
    setUploading(false)
  }, [image])

  const editItem = async () => {
    const itemEdited = {
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
      if (image) {
        const formData = new FormData()
        formData.append('files', image)
        formData.append('ref', 'api::item.item')
        formData.append('refId', item.data.id)
        formData.append('field', 'image')

        await fetch(`${API_URL}/upload`, {
          method: 'POST',
          body: formData,
        })
      }

      const res = await fetch(`${API_URL}/items/${item.data.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(itemEdited),
      })
      if (!res.ok) {
        setSubmitError('Something went wrong')
      } else {
        const item = await res.json()
        await router.push(`/items/${item.data.attributes.slug}`)
      }
    } catch (error) {
      console.log(error.message)
      setSubmitError(error.message)
    }
  }

  const { errors, values, setValues, handleChange, handleSubmit } = useValidation(
    item.data.attributes,
    newItemValidation,
    editItem
  )

  const { author, category, description, format, language, publisher, tags, title, topic, year } =
    values

  return (
    <Layout>
      <AuthStyled>
        <AuthTitle>Edit Item</AuthTitle>
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

          <InputStyled error={message}>
            <InputFile type="file" onChange={handleImageChange} />
            {message && <FormErrorMessage>{message}</FormErrorMessage>}
          </InputStyled>

          <InputStyled>
            <Input type="submit" value="Edit" error={submitError} disabled={uploading} />
            {submitError && <FormErrorMessage>{submitError}</FormErrorMessage>}
          </InputStyled>
        </Form>
      </AuthStyled>
    </Layout>
  )
}

export default EditItem

export async function getServerSideProps({ params: { id }, req }) {
  const { token } = parseCookies(req)

  if (!token) {
    return {
      redirect: {
        destination: '/auth/login',
        permanent: false,
      },
    }
  }

  const res = await fetch(`${API_URL}/items/${id}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })
  const item = await res.json()

  return {
    props: { item, token },
  }
}
