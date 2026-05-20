# mjml_red

A pure-Ruby implementation of [MJML](https://mjml.io), the email markup language. Converts MJML templates to responsive HTML emails — no Node.js, no native extensions, no shelling out.

## Feature parity with MJML

mjml_red implements the full set of standard MJML components:

**Head components:** `mj-head`, `mj-attributes`, `mj-style` (including `inline`), `mj-font`, `mj-title`, `mj-preview`, `mj-breakpoint`, `mj-html-attributes`

**Body components:** `mj-body`, `mj-section`, `mj-wrapper`, `mj-column`, `mj-group`, `mj-text`, `mj-image`, `mj-button`, `mj-divider`, `mj-spacer`, `mj-table`, `mj-raw`, `mj-hero`, `mj-social` / `mj-social-element`, `mj-navbar` / `mj-navbar-link`, `mj-accordion` / `mj-accordion-element` / `mj-accordion-title` / `mj-accordion-text`, `mj-carousel` / `mj-carousel-image`

**Features:** CSS inlining via `<mj-style inline="inline">`, global default attributes, `mj-class`, `mj-html-attributes` with CSS selectors, custom fonts, responsive breakpoints, Outlook conditionals, `lang`/`dir` attributes.

Output is tested against the upstream [MJML 4 JavaScript implementation](https://github.com/mjmlio/mjml) using fixture-based comparison and backported behavioral tests.

## Installation

Add to your Gemfile:

```ruby
gem "mjml_red"
```

Runtime dependencies: `nokogiri`, `premailer`.

## Usage

### Standalone

```ruby
require "mjml_red"

mjml = <<~MJML
  <mjml>
    <mj-body>
      <mj-section>
        <mj-column>
          <mj-text>Hello World</mj-text>
        </mj-column>
      </mj-section>
    </mj-body>
  </mjml>
MJML

html = MjmlRed.to_html(mjml)
```

### Rails

mjml_red includes a Railtie that registers an ActionView template handler automatically. Create templates with the `.html.mjml` extension:

```
app/views/user_mailer/welcome.html.mjml
```

ERB tags work inside `.mjml` templates — the handler always chains through ERB before compiling MJML:

```erb
<mjml>
  <mj-body>
    <mj-section>
      <mj-column>
        <mj-text>Welcome, <%= @user.name %>!</mj-text>
      </mj-column>
    </mj-section>
  </mj-body>
</mjml>
```

Your mailer needs no special setup:

```ruby
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email)
  end
end
```

Rails resolves the template automatically: `.mjml` selects the handler, `.html` sets the MIME type. If you also provide `welcome.text.erb`, ActionMailer sends a multipart email with both HTML and plain text parts.

## Other Ruby MJML implementations

- [mjml-rails](https://github.com/sighmon/mjml-rails) — Rails integration that shells out to the MJML Node.js binary. Requires Node.js at runtime.
- [mjml-ruby](https://github.com/kolybasov/mjml-ruby) — Ruby wrapper around the MJML Node.js parser. Also requires Node.js.
- [mrml-ruby](https://github.com/jdrouet/mrml/tree/main/packages/mrml-ruby) — Ruby bindings to [MRML](https://github.com/jdrouet/mrml), a Rust reimplementation of MJML. Requires a compiled native extension.

mjml_red differs from all of the above by being pure Ruby — it has no dependency on Node.js or native extensions.

## License

MIT
