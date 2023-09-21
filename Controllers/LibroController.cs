using AutoMapper;
using Azure;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApiAutores.DTOs;
using WebApiAutores.Entidades;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace WebApiAutores.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LibroController : ControllerBase
    {
        private readonly ApplicationDbContext context;
        private readonly IMapper mapper;

        public LibroController(ApplicationDbContext context, IMapper mapper)
        {
            this.context = context;
            this.mapper = mapper;
        }

        [HttpGet("{id:int}", Name = "ObtenerLibro")]
        public async Task<ActionResult<LibroDTOconAutores>> Get(int id)
        {
            var libro = await context.Libros.Include(libroBD => libroBD.AutoresLibros)
                .ThenInclude(autorLibroBd => autorLibroBd.Autor).FirstOrDefaultAsync(x => x.Id == id);
            return mapper.Map<LibroDTOconAutores>(libro);
        }

        [HttpPost]
        public async Task<ActionResult> Post(LibroCreacionDTO libroCreacionDto)
        {

            //validar que hayan cargado a los autores
            if (libroCreacionDto.AutoresIds == null)
            {
                return BadRequest("No se puede cargar un libro sin el autor");
            }

            //validar que existan los autores

            var autores = await context.Autores.Where(autoresBd => libroCreacionDto.AutoresIds.Contains(autoresBd.Id))
                .Select(x => x.Id).ToListAsync();
            if (libroCreacionDto.AutoresIds.Count != autores.Count)
            {
                return BadRequest("No existe alguno de los autores");
            }
            var libro = mapper.Map<Libro>(libroCreacionDto);

            context.Add(libro);
            await context.SaveChangesAsync();

            var libroDto = mapper.Map<LibroDTO>(libro);

            return CreatedAtRoute("ObtenerLibro", new { id = libro.Id }, libroDto);
        }

        //PUT api/<LibroController>/5
        [HttpPut("{id}")]
        public async Task<ActionResult> Put(int id, LibroCreacionDTO libroCreacionDTO)
        {
            var libroBD = await context.Libros.Include(x => x.AutoresLibros)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (libroBD == null) { return NotFound(); }

            libroBD = mapper.Map(libroCreacionDTO, libroBD);

            await context.SaveChangesAsync();
            return NoContent();
        }

        [HttpPatch("{id:int}")]
        public async Task<ActionResult> Patch(int id, JsonPatchDocument<LibroPatchDTO> patchDocument)
        {
            if (patchDocument == null) { return BadRequest(); }

            var libroBD = await context.Libros.FirstOrDefaultAsync(x => x.Id == id);

            if (libroBD == null) { return NotFound(); }

            var libroPatchDto = mapper.Map<LibroPatchDTO>(libroBD);

            patchDocument.ApplyTo(libroPatchDto, ModelState); // acá es donde se indican los campos a actualizar. model es para que si hay un error se coloque ahí

            var esValido = TryValidateModel(libroPatchDto);

            if (!esValido) { return BadRequest(ModelState); }

            mapper.Map(libroPatchDto, libroBD);

            await context.SaveChangesAsync();
            return NoContent();

        }

        // DELETE api/<LibroController>/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
