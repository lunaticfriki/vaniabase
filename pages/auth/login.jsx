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
import { LOGIN_INITIAL_STATE } from '../../utils'
import { loginValidation } from '../../validations'

const Login = () => {
  const { loginUser, error } = useContext(AuthContext)

  const login = async () => {
    loginUser(values)
  }

  const { errors, values, handleChange, handleSubmit } = useValidation(
    LOGIN_INITIAL_STATE,
    loginValidation,
    login
  )

  const { email, password } = values

  return (
    <Layout title="| Login">
      <AuthStyled>
        <AuthTitle>Login</AuthTitle>
        <Form onSubmit={handleSubmit} noValidate>
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
          <InputStyled>
            <Input type="submit" value="Login" error={error} />
            {error && <FormErrorMessage>{error}</FormErrorMessage>}
          </InputStyled>
          <FormErrorMessage>Not registered yet?</FormErrorMessage>{' '}
          <Link href="/auth/signup">Signup</Link>
        </Form>
      </AuthStyled>
    </Layout>
  )
}

export default Login
