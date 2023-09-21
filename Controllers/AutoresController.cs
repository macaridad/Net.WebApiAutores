using WebApiAutores.Entidades;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApiAutores.DTOs;
using AutoMapper;

namespace WebApiAutores.Controllers
{
    [Route("api/autores")]
    [ApiController]
    public class AutoresController : ControllerBase
    {
        private readonly ApplicationDbContext context;
        private readonly IMapper mapper;

        public AutoresController(ApplicationDbContext context, IMapper mapper)
        {
            this.context = context;
            this.mapper = mapper;
        }

        [HttpGet]
        public async Task<List<AutorDTO>> Get()
        {
            var autores = await context.Autores.ToListAsync();
            return mapper.Map<List<AutorDTO>>(autores);
        }
        [HttpGet("{id:int}", Name = "ObtenerAutor")]
        public async Task<ActionResult<AutorDTOconLibros>> Get(int id)
        {
            var autor = await context.Autores
                .Include(autorBD => autorBD.AutoresLibros)
                .ThenInclude(autorLibro => autorLibro.Libro)
                .FirstOrDefaultAsync(x => x.Id == id);
            if(autor == null)
            {
                return NotFound();
            }
            return mapper.Map<AutorDTOconLibros>(autor);
        }

        [HttpPost]
        public async Task<ActionResult> Post (AutorCreacionDTO autorCreacionDto)
        {
            var autor = mapper.Map<Autor>(autorCreacionDto);

            context.Add(autor);
            await context.SaveChangesAsync();

            var autorDto = mapper.Map<AutorDTO>(autor);

            return CreatedAtRoute("ObtenerAutor", new {id = autor.Id}, autorDto);
        }

        [HttpPut("{id:int}")]
        public async Task<ActionResult> Put(AutorCreacionDTO autorCreacionDto, int id) //no podemos usar Autor para no exponer nuestras entidades
        {
            //if(autor.Id != id)
            //{
            //    return BadRequest("El id del autor no coincide con la URL");
            //} no es necesario porque AutorCreacionDto no trae id, pero lo tengo que mapear.
            var existe = await context.Autores.AnyAsync(x => x.Id == id);
            if (!existe)
            {
                return NotFound();
            }

            var autor = mapper.Map<Autor>(autorCreacionDto);
            autor.Id = id;

            context.Update(autor);
            await context.SaveChangesAsync();
            return NoContent();
        }

        [HttpDelete("{id:int}")]
        public async Task<ActionResult> Delete(int id)
        {
            var existe = await context.Autores.AnyAsync(x => x.Id == id);
            if(!existe)
            {
                return NotFound();
            }
            context.Remove(new Autor() { Id = id });
            await context.SaveChangesAsync();
            return Ok();
        }
        
    }
}
