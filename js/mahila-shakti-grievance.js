import { supabase } from "./supabaseClient.js";

document.addEventListener("DOMContentLoaded", async () => {
  // No session check required, anyone can submit
  const form = document.querySelector(".form-container form");
  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      // Handle file uploads (attachments)
      let attachmentUrls = [];
      const files = document.getElementById("ms_attachments").files;
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const { data, error } = await supabase.storage
          .from("mahila-shakti-files")
          .upload(`attachments/${Date.now()}_${file.name}`, file);
        if (!error) attachmentUrls.push(data.path);
      }

      // Collect checkbox values for grievance type
      const grievanceTypes = Array.from(
        document.querySelectorAll('input[name="ms_grievance_type"]:checked')
      ).map((el) => el.value);

      // Collect checkbox values for response mode
      const responseModes = Array.from(
        document.querySelectorAll('input[name="ms_response_mode"]:checked')
      ).map((el) => el.value);

      // Volunteer radio
      const volunteer = document.querySelector(
        'input[name="ms_volunteer"]:checked'
      )?.value;

      // Declaration checkbox
      const declaration = document.querySelector(
        'input[name="ms_declaration"]:checked'
      )
        ? true
        : false;

      // Try to get user_id if logged in, else leave undefined
      let user_id = undefined;
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession();
        if (session && session.user && session.user.id) {
          user_id = session.user.id;
        }
      } catch (e) {}

      // Insert grievance
      const { error } = await supabase.from("mahila_shakti_grievances").insert([
        {
          user_id: user_id,
          fullname: document.getElementById("ms_fullname").value,
          age: parseInt(document.getElementById("ms_age").value),
          gender: document.querySelector('input[name="ms_gender"]:checked')
            ?.value,
          mobile: document.getElementById("ms_mobile").value,
          email: document.getElementById("ms_email").value,
          district: document.getElementById("ms_district").value,
          constituency: document.getElementById("ms_constituency").value,
          mandal: document.getElementById("ms_mandal").value,
          ward: document.getElementById("ms_ward").value,
          grievance_types: grievanceTypes,
          grievance_other: document.querySelector(
            'input[name="ms_grievance_other"]'
          )?.value,
          description: document.getElementById("ms_description").value,
          attachments: attachmentUrls,
          response_modes: responseModes,
          volunteer: volunteer,
          declaration: declaration,
        },
      ]);

      if (error) {
        alert("Submission failed: " + (error.message || JSON.stringify(error)));
        console.error(error);
      } else {
        alert("Your grievance has been submitted successfully!");
        form.reset();
      }
    });
  }
});
