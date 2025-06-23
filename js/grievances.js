import { supabase } from "./supabaseClient.js";

document.addEventListener("DOMContentLoaded", async () => {
  // Check if user is signed in
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) {
    alert("You must be signed in to submit this form.");
    window.location.href = "signin.html";
    return;
  }

  const form = document.querySelector(".form-container form");
  if (form) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      // Handle file uploads (attachments)
      let attachmentUrls = [];
      const files = document.getElementById("attachments").files;
      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const { data, error } = await supabase.storage
          .from("grievance-files")
          .upload(`attachments/${Date.now()}_${file.name}`, file);
        if (!error) attachmentUrls.push(data.path);
      }

      // Insert grievance
      const { error } = await supabase.from("grievances").insert([
        {
          user_id: session.user.id,
          fullname: document.getElementById("fullname").value,
          age: parseInt(document.getElementById("age").value),
          gender: document.getElementById("gender").value,
          mobile: document.getElementById("mobile").value,
          email: document.getElementById("email").value,
          address: document.getElementById("address").value,
          caste: document.getElementById("caste").value,
          aadhaar: document.getElementById("aadhaar").value,
          grievance: document.getElementById("grievance").value,
          grievance_other: document.querySelector(
            'input[name="grievance_other"]'
          ).value,
          details: document.getElementById("details").value,
          attachments: attachmentUrls,
          political_sensitive: document.querySelector(
            'input[name="political_sensitive"]:checked'
          )?.value,
          parties: document.getElementById("parties")?.value,
          anonymous: document.querySelector('input[name="anonymous"]:checked')
            ?.value,
          opponent_name:
            document.getElementById("opponent_name")?.value || null,
          opponent_phone:
            document.getElementById("opponent_phone")?.value || null,
          opponent_details:
            document.getElementById("opponent_details")?.value || null,
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
