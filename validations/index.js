export const signupValidation = (values) => {
  let errors = {}

  if (!values.username) {
    errors.username = 'Username is required'
  }

  if (!values.email) {
    errors.email = 'Email is required'
  } else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(values.email)) {
    errors.email = 'Email format is not valid'
  }

  if (!values.password) {
    errors.password = 'Password is required'
  } else if (values.password.length < 6) {
    errors.password = 'Minimum 6 characters required'
  }

  if (!values.repeat) {
    errors.repeat = 'Repeat password is required'
  } else if (values.password !== values.repeat) {
    errors.repeat = "Passwords don't match"
  }

  return errors
}

export const loginValidation = (values) => {
  let errors = {}

  if (!values.email) {
    errors.email = 'Email is required'
  } else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(values.email)) {
    errors.email = 'Email format is not valid'
  }

  if (!values.password) {
    errors.password = 'Password is required'
  } else if (values.password.length < 6) {
    errors.password = 'Minimum 6 characters requried'
  }

  return errors
}

export const newItemValidation = (values) => {
  let errors = {}

  if (!values.title) {
    errors.title = 'Title is required'
  }

  if (!values.category) {
    errors.category = 'Category is required'
  }

  return errors
}
