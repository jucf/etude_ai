# clear environnement
rm(list = ls())

library(googlesheets4)
library(dplyr)
library(mailR)
library(stringr)
library(tidyverse)


attach_and_send_pdf <-
  function(data, email_from, subject, body) {
    for (i in seq_len(nrow(data))) {
      # Extract nom, prenom, and email from the data frame
      prenom <- as.character(data[i, "prenom"])
      nom <- as.character(data[i, "nom"])
      email <- as.character(data[i, "courriel"])
      
      # Print out email for debugging
      cat("Email:", email, "\n")
      
      # Check if email is null or empty
      if (is.null(email) || nchar(email) == 0) {
        cat("Skipping email for",
            nom,
            "since email address is null or empty.\n")
        next
      }
      
      # Construct PDF file path
      pdf_filename <- paste(nom, "*.pdf", sep = "_")
      pdf_path <- list.files(path = "~/Desktop/Ltips/etude_ai",
                             pattern = pdf_filename,
                             full.names = TRUE)[1]  # Assuming only one PDF file matches
      
      # Print out PDF file path for debugging
      cat("PDF path:", pdf_path, "\n")
      
      # Check if PDF file exists
      if (length(pdf_path) == 0) {
        cat("PDF file not found for", nom, "\n")
        next
      }
      
      # Customize the message body
      body <- paste(
        "Bonjour ",
        prenom,
        ",",
        "\n\nEn pièce jointe, tu trouveras ton rapport d'analyse mensuel.",
        "\n\nNous aurons également une réunion Zoom ce vendredi pour discuter des informations fournies.",
        "\n\nJe te remercie beaucoup pour ton implication et ta collaboration jusqu'à présent dans le projet de recherche.",
        "\n\nÀ bientôt et bon entraînement,",
        "\nJules",
        sep = ""
      )
      
      # Attach and send email
      email_message <- tryCatch({
        send.mail(
          from = email_from,
          to = email,
          subject = subject,
          body = body,
          attach.files = pdf_path,
          # Use attach.files instead of attachments
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
      },
      error = function(e)
        e)
      
      # Check if email sending is successful
      if (inherits(email_message, "error")) {
        cat("Error sending email to",
            email,
            "for",
            nom,
            ": ",
            email_message$message,
            "\n")
      } else {
        cat("Email sent to", email, "for", nom, "\n")
      }
    }
  }

# Load data
# each nom need to be separated by - to match pdf name mateo was not in default gsheet df
data <- read_csv("email_data.csv") 
# |> 
# mutate(nom = gsub(" ", "-", nom))

attach_and_send_pdf(data,
                    email_from = "jules.cusson.fradet@gmail.com",
                    subject = "Rapport mensuel - projet de recherche L-Tips-UQTR")
