library(googlesheets4)
library(dplyr)
library(mailR)

# utiliser UTC time now pour cron job
# 5h am UTC pour minuit QC et 6h am france

# connecter au compte
# googlesheets4::gs4_auth()

sheets_deauth()
# Google Sheets URL
ss_url <- "https://docs.google.com/spreadsheets/d/1pBGkvxKph4C9PsQtpgaD9_zcOlOgbQESwXcp3y-t0eU/edit?resourcekey#gid=685045347"

# Read data from Google Sheets
data <- read_sheet(ss_url, sheet = "info") %>% 
  # enlever 2 FR
  slice(-c(27, 29))


# Define a function to send an email with a custom link
send_email <- function(name, email, link) {
  subject <- "Questionnaire et HRV quotidien L-tips-UQTR"
  body <-
    sprintf(
      "Bonjour %s,\n\nPetit rappel: n'oublie pas de consacrer quelques minutes à compléter ton suivi quotidien en utilisant le lien ci-dessous:\n%s\n\nN'oublie pas également de mesurer ta HRV en position assise après avoir rempli ton questionnaire.\n\nTon engagement est essentiel pour faire progresser notre recherche. Merci infiniment pour ta précieuse collaboration !\n\nL'équipe du L-tips",
      name,
      link
    )
  
  # Check if the email address is not null or empty
  if (!is.null(email) && nchar(email) > 0) {
    
    # Set email details
    email_from <- "jules.cusson.fradet@gmail.com"  # Replace with your email
    
    # Create an email
    email_message <- send.mail(
      from = email_from,
      to = email,
      subject = subject,
      body = body,
      smtp = list(
        host.name = "smtp.gmail.com",
        port = 587,
        user.name = "jules.cusson.fradet@gmail.com",
        passwd = "djtbdzpvublijziv",
        ssl = TRUE
      ),
      authenticate = TRUE,
      send = TRUE
    )
    
    # Return the email message
    return(email_message)
  } else {
    # Print a message or handle the case where the email address is null or empty
    cat("Invalid email address:", email, "\n")
    return(NULL)
  }
}

# Define a function for your condition
condition_to_send_email <- function(link) {
  return(!is.na(link) && link != "")
}

# Iterate through each row
for (i in seq_len(nrow(data))) {
  if (condition_to_send_email(data[i, "lien_rempli_forms"])) {
    send_result <- send_email(data[i, "prenom"], data[i, "courriel"], data[i, "lien_rempli_forms"])
    
    # Check the result of sending the email
    if (is.null(send_result)) {
      cat("Email not sent for row:", i, "\n")
    } else {
      cat("Email sent successfully for row:", i, "\n")
    }
  }
}