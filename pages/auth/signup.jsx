import { useContext } from 'react'
import Link from 'next/link'

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
} from '../../components/common/form'

// VALIDATION
import useValidation from '../../hooks/useValidation'
import { SIGNUP_INITIAL_STATE } from '../../utils'
import { signupValidation } from '../../validations'

const Signup = () => {
  const { registerUser, error } = useContext(AuthContext)

  const register = async () => {
    registerUser(values)
  }

  const { errors, values, handleChange, handleSubmit } = useValidation(
    SIGNUP_INITIAL_STATE,
    signupValidation,
    register
  )

  const { username, email, password, repeat } = values

  return (
    <Layout>
      <AuthStyled>
        <AuthTitle>Signup</AuthTitle>
        <Form onSubmit={handleSubmit} noValidate>
          <InputStyled error={errors.username}>
            <Input
              type="text"
              id="username"
              name="username"
              placeholder="Username"
              value={username}
              onChange={handleChange}
              error={errors.username}
            />
            {errors.username && <FormErrorMessage>{errors.username}</FormErrorMessage>}
          </InputStyled>
          <InputStyled error={errors.email}>
            <Input
              type="email"
              name="email"
              id="email"
              placeholder="Email"
              value={email}
              onChange={handleChange}
              error={errors.email}
            />
            {errors.email && <FormErrorMessage>{errors.email}</FormErrorMessage>}
          </InputStyled>
          <InputStyled error={errors.password}>
            <Input
              type="password"
              name="password"
              id="password"
              placeholder="Password"
              value={password}
              onChange={handleChange}
              error={errors.password}
            />
            {errors.password && <FormErrorMessage>{errors.password}</FormErrorMessage>}
          </InputStyled>
          <InputStyled error={errors.repeat}>
            <Input
              type="password"
              name="repeat"
              id="repeat"
              placeholder="Repeat password"
              value={repeat}
              onChange={handleChange}
              error={errors.repeat}
            />
            {errors.repeat && <FormErrorMessage>{errors.repeat}</FormErrorMessage>}
          </InputStyled>
          <InputStyled>
            <Input type="submit" value="Signup" error={error} />
            {error && <FormErrorMessage>{error}</FormErrorMessage>}
          </InputStyled>
          <FormErrorMessage>Already a user?</FormErrorMessage> <Link href="/auth/login">Login</Link>
        </Form>
      </AuthStyled>
    </Layout>
  )
}

export default Signup
